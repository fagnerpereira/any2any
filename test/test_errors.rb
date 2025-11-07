# frozen_string_literal: true

require 'test_helper'

class TestErrors < Minitest::Test
  def test_parse_error_exists
    assert_kind_of Class, Any2Any::ParseError
  end

  def test_unsupported_format_error_exists
    assert_kind_of Class, Any2Any::UnsupportedFormat
  end

  def test_error_classes_inherit_from_standard_error
    assert Any2Any::ParseError < StandardError
    assert Any2Any::UnsupportedFormat < StandardError
  end

  def test_warning_collector_exists
    collector = Any2Any::WarningCollector.new
    assert_instance_of Any2Any::WarningCollector, collector
  end

  def test_warning_collector_add_warning
    collector = Any2Any::WarningCollector.new
    warning = Any2Any::ConversionWarning.new(
      line: 1,
      column: 5,
      message: 'Test warning',
      severity: :warning
    )
    
    collector.add(warning)
    assert_equal 1, collector.all.length
  end

  def test_warning_collector_all
    collector = Any2Any::WarningCollector.new
    assert_equal 0, collector.all.length
    
    warning = Any2Any::ConversionWarning.new(message: 'Test')
    collector.add(warning)
    assert_equal 1, collector.all.length
  end

  def test_warning_collector_has_errors
    collector = Any2Any::WarningCollector.new
    assert_equal false, collector.has_errors?
    
    error_warning = Any2Any::ConversionWarning.new(message: 'Error', severity: :error)
    collector.add(error_warning)
    assert_equal true, collector.has_errors?
  end

  def test_warning_collector_filter_by_severity
    collector = Any2Any::WarningCollector.new
    
    collector.add(Any2Any::ConversionWarning.new(message: 'Info', severity: :info))
    collector.add(Any2Any::ConversionWarning.new(message: 'Warning', severity: :warning))
    collector.add(Any2Any::ConversionWarning.new(message: 'Error', severity: :error))
    
    assert_equal 1, collector.errors.length
    assert_equal 1, collector.warnings.length
    assert_equal 1, collector.infos.length
  end

  def test_warning_collector_clear
    collector = Any2Any::WarningCollector.new
    collector.add(Any2Any::ConversionWarning.new(message: 'Test'))
    
    assert_equal 1, collector.all.length
    collector.clear
    assert_equal 0, collector.all.length
  end

  def test_warning_collector_summary
    collector = Any2Any::WarningCollector.new
    summary = collector.summary
    
    assert summary.include?('Conversion complete')
  end

  def test_warning_collector_to_s
    collector = Any2Any::WarningCollector.new
    collector.add(Any2Any::ConversionWarning.new(message: 'Test warning'))
    
    string = collector.to_s
    assert string.include?('Test warning')
  end

  def test_conversion_warning_creation
    warning = Any2Any::ConversionWarning.new(
      line: 10,
      column: 5,
      message: 'Test warning',
      severity: :warning,
      suggestion: 'Try this instead'
    )
    
    assert_equal 10, warning.line
    assert_equal 5, warning.column
    assert_equal 'Test warning', warning.message
    assert_equal :warning, warning.severity
    assert_equal 'Try this instead', warning.suggestion
  end

  def test_conversion_warning_to_s
    warning = Any2Any::ConversionWarning.new(
      line: 10,
      message: 'Test warning'
    )
    
    string = warning.to_s
    assert string.include?('Line 10')
    assert string.include?('Test warning')
  end

  def test_conversion_warning_without_line
    warning = Any2Any::ConversionWarning.new(message: 'Test warning')
    
    string = warning.to_s
    assert string.include?('Test warning')
  end
end
