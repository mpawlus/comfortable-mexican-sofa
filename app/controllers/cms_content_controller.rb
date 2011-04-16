class CmsContentController < ApplicationController
  
  before_filter :load_cms_site
  before_filter :load_cms_page,   :only => :render_html
  before_filter :load_cms_layout, :only => [:render_css, :render_js]
  
  caches_page :render_css, :render_js, :if => Proc.new { |c| ComfortableMexicanSofa.config.enable_caching }
  
  def render_html(status = 200)
    layout = @cms_page.layout.app_layout.blank?? false : @cms_page.layout.app_layout
    render :inline => @cms_page.content, :layout => layout, :status => status
  end
  
  def render_css
    render :text => @cms_layout.css, :content_type => 'text/css'
  end
  
  def render_js
    render :text => @cms_layout.js, :content_type => 'text/javascript'
  end
  
protected
  
  def load_cms_site
    @cms_site = if ComfortableMexicanSofa.config.enable_multiple_sites
      Cms::Site.find_by_hostname!(request.host.downcase)
    else
      Cms::Site.first
    end
  rescue ActiveRecord::RecordNotFound
    render :text => 'Site Not Found', :status => 404
  end
  
  def load_cms_page
    @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")
    return redirect_to(@cms_page.target_page.full_path) if @cms_page.target_page
    
  rescue ActiveRecord::RecordNotFound
    if @cms_page = @cms_site.pages.published.find_by_full_path('/404')
      render_html(404)
    else
      render :text => 'Page Not Found', :status => 404
    end
  end
  
  def load_cms_layout
    @cms_layout = @cms_site.layouts.find_by_slug!(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end
  
end
