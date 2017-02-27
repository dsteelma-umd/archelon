#
# URL helper methods
module UrlHelper
 include Blacklight::UrlHelperBehavior 

  # link_to_document(doc, 'VIEW', :counter => 3)
  # Overrides the Blacklight default behavior in order to not include the '/track' url suffix in the results view.
  # The /track url do not work with constraints: { id: /.*/ } configured in the routes.rb
  def link_to_document(doc, field_or_opts = nil, opts={:counter => nil})
    if field_or_opts.is_a? Hash
      opts = field_or_opts
    else
      field = field_or_opts
    end

    field ||= document_show_link_field(doc)
    label = index_presenter(doc).label field, opts
    link_to label, url_for_document(doc), opts

  end

end
