# frozen_string_literal: true

# Component for displaying Archelon-based container links for a Solr
# document.
#
# This component is typically used to generate a "back link" to the container
# page from one of the "contained" items in the container.
#
# Given a Solr document, extracts the specified field from the document (the
# value is assumed to an fcrep URL), then queries Solr, retrieving the
# "container" Solr document.
#
# The component then does the following:
#
#   1) The fcrepo URL is converted into a Archelon-based URL for the same item.
#
#   2) Using the the provided "container_title_field" or
#      "container_title_accessor" field (see below), generates human-readable
#      text to display with the link.
#
# This component adds the following fields to the field configuration:
#
# * container_title_field - the field in the retrieved Solr document to use
#   as the human-readable text for the link.
#
# * container_title_accessor - the SolrDocument method to call on the retrieved
#   Solr document to generate the human-readable text for the link.
#
# Typically, only one of these fields is provided. If both are provided, the
# "container_title_accessor" field will take precedence.
#
# If neither field is provided, the link will be returned AS-IS, with the
# human-readable text being the value of the Solr field.
#
# Note: This component makes a Solr query for each instance where it is used
# on a page.
class ArchelonContainerLinkComponent < Blacklight::MetadataFieldComponent
  def before_render
    container_document_id = @field.field_config.key
    container_document = controller.search_service.fetch(@field.document[container_document_id])

    # Default - convert link to Archelon-based link with link as text
    # Note: This is "fallback" behavior and likely not ideal. Consider
    # specifying a "container_title_field" or "container_title_accessor"
    # to get more human-friendly link text.
    #
    # Using solr_document_url instead of solr_document_path, because the
    # link is actually displayed to the user.
    @container_title = solr_document_url(@field.render)
    @container_link = solr_document_url(@field.render)

    # Handle "container_title_field" field configuration (if provided)
    if @field.field_config.key?(:container_title_field)
      container_title_field = @field.field_config[:container_title_field]
      @container_title = container_document[container_title_field]
      @container_link = solr_document_path(@field.render)
    end

    # Handle "container_title_accessor" field configuration (if provided)
    if @field.field_config.key?(:container_title_accessor)
      container_title_accessor = @field.field_config[:container_title_accessor]
      @container_title = container_document.send(container_title_accessor)
      @container_link = solr_document_path(@field.render)
    end
  end
end
