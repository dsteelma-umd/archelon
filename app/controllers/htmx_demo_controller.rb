class HtmxDemoController < ApplicationController
  def index
  end
  def replace
    subject = params['subject']
    predicate = params['predicate']
    original_value = params['original_value']
    new_value = params['new_value']
    value_type = params['value_type']

    original_value_and_type = value_type == "" ?  "&quot;#{original_value}&quot;": "&quot;#{original_value}&quot;^^<#{value_type}>"
    new_value_and_type = value_type == "" ?  "&quot;#{new_value}&quot;": "&quot;#{new_value}&quot;^^<#{value_type}>"

    render html: """
    <input type='hidden' name='delete[]' value='<#{subject}> <#{predicate}> #{original_value_and_type} .\r\n'>
    <input type='hidden' name='insert[]' value='<#{subject}> <#{predicate}> #{new_value_and_type} .\r\n'>
    """.html_safe
  end
 end
