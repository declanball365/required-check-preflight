require 'minitest/autorun'
require_relative 'preflight'

class PreflightTest < Minitest::Test
  def codes(events, job = {'runs-on' => 'ubuntu-latest'}, required = ['test'], queue = false)
    Preflight.inspect_workflow({'on' => events, 'jobs' => {'test' => job}}.to_yaml, required, merge_queue: queue)[:findings].map { |f| f[:code] }
  end
  def test_unquoted_on_and_path_filter
    yaml = "on:\n  pull_request:\n    paths: ['src/**']\njobs:\n  test:\n    runs-on: ubuntu-latest\n"
    assert_equal ['FILTERED_REQUIRED_CHECK'], Preflight.inspect_workflow(yaml, ['test'])[:findings].map { |f| f[:code] }
  end
  def test_each_filter
    %w[paths paths-ignore branches branches-ignore].each { |f| assert_equal ['FILTERED_REQUIRED_CHECK'], codes({'pull_request' => {f => ['x']}}) }
  end
  def test_unfiltered_control
    assert_empty codes('pull_request')
  end
  def test_job_condition_not_workflow_skip
    assert_empty codes('pull_request', {'if' => 'false'})
  end
  def test_push_only_filters_not_pr_filters
    assert_empty codes({'push' => {'paths' => ['x']}, 'pull_request' => nil})
  end
  def test_queue_explicit
    assert_equal ['MISSING_MERGE_GROUP'], codes('pull_request', {}, ['test'], true)
    assert_empty codes(['pull_request', 'merge_group'], {}, ['test'], true)
  end
  def test_missing_mapping
    assert_equal ['UNKNOWN_MAPPING'], codes('pull_request', {}, ['missing'])
  end
  def test_custom_name
    assert_empty codes('pull_request', {'name' => 'Unit tests'}, ['Unit tests'])
  end
  def test_unsupported_expansion
    [{'strategy' => {'matrix' => {'os' => ['linux']}}}, {'uses' => './reusable.yml'}].each { |job| assert_equal ['UNKNOWN_MAPPING'], codes('pull_request', job) }
  end
  def test_ambiguous_name
    yaml = {'on' => 'pull_request', 'jobs' => {'a' => {'name' => 'test'}, 'b' => {'name' => 'test'}}}.to_yaml
    assert_equal 'UNKNOWN_MAPPING', Preflight.inspect_workflow(yaml, ['test'])[:findings][0][:code]
  end
  def test_no_pr_trigger
    assert_equal ['UNKNOWN_PR_TRIGGER'], codes('push')
  end
  def test_bad_inputs
    assert_raises(ArgumentError) { Preflight.inspect_workflow('[]', ['test']) }
    assert_raises(ArgumentError) { codes('pull_request', {}, []) }
    assert_raises(Psych::Exception) { Preflight.inspect_workflow('!ruby/object:Object {}', ['test']) }
    assert_raises(Psych::Exception) { Preflight.inspect_workflow("on: &x [pull_request]\njobs: *x", ['test']) }
  end
end
