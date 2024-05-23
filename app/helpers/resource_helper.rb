# frozen_string_literal: true

module ResourceHelper
  # # generate a lookup hash of (predicate, datatype) => fieldname
  # def uri_to_fieldname(fields)
  #   Hash[fields.map { |field| [[field[:uri], field[:datatype]], field[:name]] }]
  # end

  def get_field_values(item, field)
    # for fields with a particular datatype, check the value type as well as the predicate URI
    field_predicate_uri = field[:uri]
    item_values_for_predicate = item[field_predicate_uri] || []

    field_data_type = field[:datatype]
    item_values_for_predicate.select { |value| value['@type'] == field_data_type }
  end

  # Returns true if HTMX should be subsituted for the the given React
  # component, false otherwise.
  def substitute_htmx(args)
    is_repeatable = (args[:maxValues] != 1)
    return false if is_repeatable

    component_type = args[:componentType]
    !htmx_partial(component_type).nil?
  end

  # Returns the HTMX partial for the given React component type, or nil if
  # no HTMX partial exists for that React component type
  def htmx_partial(component_type)
    case component_type
    when :TypedLiteral
      'resource/htmx/typed_literal'
    else
      nil
    end
  end

  def define_react_components(fields, items, uri) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    item = items[uri]
    fields.map do |field|
      component_type = :Repeatable
      component_args = {
        name: field[:name],
        # this will group fields by their subject ...
        subjectURI: uri,
        # ... and key them by their predicate
        predicateURI: field[:uri],
        componentType: field[:type],
        values: get_field_values(item, field)
      }.tap do |args|
        args[:vocab] = get_vocab_hash(field) if field[:vocab].present?
        args[:maxValues] = 1 unless field[:repeatable]

        # special handling for LabeledThing fields
        if field[:type] == :LabeledThing
          args[:values] = args[:values]&.map do |value|
            get_labeled_thing_value(value, items)
          end
        end

        # special handling for the access level field
        configure_access_level(args, item) if field[:name] == 'access'
      end
      [field[:label], component_type, component_args]
    end
  end

  def get_vocab_hash(field)
    VocabularyService.vocab_options_hash(field)
  end

  def get_labeled_thing_value(value, items)
    target_uri = value.fetch('@id', nil)
    return value unless target_uri

    obj = items[target_uri]
    label = obj&.fetch(LABEL_PREDICATE, nil)&.first
    same_as = obj&.fetch(SAME_AS_PREDICATE, nil)&.first

    { value: value }.tap do |v|
      v[:label] = label if label
      v[:sameAs] = same_as if same_as
    end
  end

  def configure_access_level(args, item)
    args[:values] = item.fetch('@type', []).select { |uri| args[:vocab].include? uri }.map { |uri| { '@id' => uri } }
    args[:predicateURI] = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
  end
end
