class HtmxDemoController < ApplicationController
  def index
  end
  def replace
    subject = params['subject']
    predicate = params['predicate']
    original_value = params['original_value']
    new_value = params['new_value']
    value_type = params['value_type']

    render html: """
    <input type='hidden' name='value_type' value='#{value_type}'>
    <input type='hidden' name='subject' value='#{subject}'>
    <input type='hidden' name='predicate' value='#{predicate}'>
    <input type='hidden' name='original_value' value='#{original_value}'>

    <input type='hidden' name='delete[]' value='<#{subject}> <#{predicate}> &quot;#{original_value}&quot;^^<#{value_type}> .'>
    <input type='hidden' name='insert[]' value='<#{subject}> <#{predicate}> &quot;#{new_value}&quot;^^<#{value_type}> .'>
    """.html_safe
  end
 end
