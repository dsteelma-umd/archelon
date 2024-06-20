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

  def repeatable_remove
    remove_index = params[:index].to_i
    repeatable_id = params['repeatable_id']
    repeatable_param = JSON.parse(params[repeatable_id])
    subject = repeatable_param['subject']
    predicate = repeatable_param['predicate']
    original_value = repeatable_param['original_value']
    new_value = repeatable_param['new_value']
    value_type = repeatable_param['value_type']

    args = JSON.parse(params[repeatable_id+"-original-values"]).with_indifferent_access
    deleted_values = args['deleted_values'] || []
    args_values = args['values']

    if remove_index <= args_values.size()
      deleted_entry = args_values[remove_index]
      # sparql_delete = '<input type="hidden" name="delete[]" value="' + deleted_value['@value'] +
      #       t} disabled={this.props.value.isNew || this.noStartingValue || valueIsUnchanged}/>'"

      deleted_value = deleted_entry["@value"]
      deleted_type = deleted_entry["@type"]
      deleted_value_and_type = (deleted_type.nil? || deleted_type.empty?) ?  "&quot;#{deleted_value}&quot;": "&quot;#{deleted_value}&quot;^^<#{deleted_type}>"

      deleted_values.push(deleted_value_and_type)
      args['deleted_values'] = deleted_values
      args_values.delete_at(remove_index)

      # TODO add to repeatable include/delete SPARQL
    end

    #--- From repeatable_htmx_component(original_args)
    @repeatable_id = SecureRandom.uuid
    args_array = []

    for value in args[:values]
      component_args = args.deep_dup.with_indifferent_access
      component_args.delete(:values)
      component_args[:value] = value
      args_array << component_args
    end

    original_args = { (@repeatable_id + "-original-values") => args }.to_json
    render partial: 'resource/htmx/repeatable.html.erb', locals: {
        original_args: original_args,
        type: args[:componentType],
        args_array: args_array,
        deleted_values: deleted_values,
        subject: subject,
        predicate: predicate,
      }, layout: false

    # original_value_and_type = value_type == "" ?  "&quot;#{original_value}&quot;": "&quot;#{original_value}&quot;^^<#{value_type}>"
    # byebug
    # render html:"""
    # <input hx-swap-oob='beforeend: .repeatable' previous type='hidden' name='delete[]' value='<#{subject}> <#{predicate}> #{original_value_and_type} .\r\n'>
    # """.html_safe
  end


 end
