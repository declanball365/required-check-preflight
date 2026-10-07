# Private feasibility prototype. Reads YAML as data; never executes workflows.
require 'yaml'
require 'json'

module Preflight
  def self.inspect_workflow(yaml, required, merge_queue: false)
    raise ArgumentError, 'required checks must be a nonempty array of strings' unless required.is_a?(Array) && !required.empty? && required.all? { |v| v.is_a?(String) && !v.empty? }
    doc = YAML.safe_load(yaml, permitted_classes: [], permitted_symbols: [], aliases: false)
    raise ArgumentError, 'workflow must contain a jobs mapping' unless doc.is_a?(Hash) && doc['jobs'].is_a?(Hash)
    # Psych uses YAML 1.1 and interprets the unquoted GitHub key on as true.
    trigger = doc.key?('on') ? doc['on'] : doc[true]
    events = case trigger
             when String then {trigger => nil}
             when Array
               raise ArgumentError, 'invalid event list' unless trigger.all? { |v| v.is_a?(String) }
               trigger.each_with_object({}) { |v, h| h[v] = nil }
             when Hash then trigger
             else raise ArgumentError, 'unsupported or missing workflow events'
             end
    findings = []
    required.each do |check|
      candidates = doc['jobs'].select do |id, job|
        job.is_a?(Hash) && (job['name'] || id) == check
      end
      if candidates.size != 1
        findings << {check: check, code: 'UNKNOWN_MAPPING', detail: 'Expected one exact static job name in this workflow; inspect other workflows and expanded check names.'}
        next
      end
      id, job = candidates.first
      if job.key?('strategy') || job.key?('uses') || check.include?('${{')
        findings << {check: check, job: id, code: 'UNKNOWN_MAPPING', detail: 'Matrix, dynamic names and reusable workflows require expanded check context.'}
        next
      end
      pr = events['pull_request']
      if pr.is_a?(Hash)
        filters = %w[paths paths-ignore branches branches-ignore].select { |key| pr.key?(key) }
        unless filters.empty?
          findings << {check: check, job: id, code: 'FILTERED_REQUIRED_CHECK', detail: "Workflow-level #{filters.join(', ')} can suppress this required check. Review an unfiltered required gate with job-level change detection; preserve failure propagation."}
        end
      end
      unless events.key?('pull_request')
        findings << {check: check, job: id, code: 'UNKNOWN_PR_TRIGGER', detail: 'No pull_request event; verify how a check is produced for the tested commit. Alternate event semantics are not evaluated.'}
      end
      if merge_queue && !events.key?('merge_group')
        findings << {check: check, job: id, code: 'MISSING_MERGE_GROUP', detail: 'Merge queue was explicitly enabled in input, but this workflow has no merge_group trigger.'}
      end
    end
    {scope: 'Single-workflow configuration risks only; not mergeability or a safety certification.', findings: findings}
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    raise ArgumentError, 'Usage: ruby preflight.rb WORKFLOW.yml REQUIRED.json [--merge-queue]' unless (2..3).cover?(ARGV.size) && (ARGV.size == 2 || ARGV[2] == '--merge-queue')
    puts JSON.pretty_generate(Preflight.inspect_workflow(File.read(ARGV[0]), JSON.parse(File.read(ARGV[1])), merge_queue: ARGV[2] == '--merge-queue'))
  rescue Psych::Exception, JSON::ParserError, ArgumentError, SystemCallError => e
    warn "Input rejected: #{e.class}"
    exit 2
  end
end
