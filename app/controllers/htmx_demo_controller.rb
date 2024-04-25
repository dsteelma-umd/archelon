class HtmxDemoController < ApplicationController
  def index
  end
  def replace
    render html: '<div>Button was clicked</div>'.html_safe
  end
 end
