#encoding: UTF-8
require 'rest_client'
# we reference this formatters
require 'rspec/core/formatters/progress_formatter'
require 'rspec/core/formatters/html_formatter'

shared_context "create user", :need_user => true do
  before {
    # 测试之前，创建临时账户
    @user = create(:user)
    @baichebao_user = create(:baichebao_user)
  }
  
  after {
    # 测试之后，删除账户
    @user.destroy
    @baichebao_user.destroy
  }
  
  def puts_req(s)
    puts '<h5>输入参数（HTTP request body）:</h5><p><pre>'
    puts s
    puts '</pre></p>'
  end

  def puts_resp(s)
    puts '<h5>返回值（HTTP response body）:</h5><p><pre>'
    puts s
    puts '</pre></p>'
  end

  def puts_url(s)
    puts '<h4><strong>URL:&nbsp&nbsp'
    puts s.sub('localhost:3000','115.28.132.220:81')
    puts '<br/>HTTP Headers:</strong></h4><p><pre>Content-Type: application/json</pre></p><p><pre>Accept: application/json</pre></p>'
  end
  
  def is_html_format
    RSpec.configuration.formatters[0].is_a?(RSpec::Core::Formatters::HtmlFormatter)
  end

  def get_json(url, show_in_doc = true)
    puts '<h5>METHOD:&nbsp&nbspGET</h5>' if show_in_doc && is_html_format
    puts_url url if show_in_doc && is_html_format
    response_json = RestClient.get url, :content_type => :json, :accept => :json
    puts_resp JSON.pretty_generate(JSON.parse(response_json)) if response_json.to_s != '' && show_in_doc && is_html_format
    response_json
  end

  def delete_json(url, show_in_doc = true)
    puts '<h5>METHOD:&nbsp&nbspDELETE</h5>' if show_in_doc && is_html_format
    puts_url url if show_in_doc && is_html_format
    response_json = RestClient.delete url, :content_type => :json, :accept => :json
    puts_resp JSON.pretty_generate(JSON.parse(response_json)) if response_json.to_s != '' && show_in_doc && is_html_format
    response_json
  end

  def put_json(url, req, show_in_doc = true)
    puts '<h5>METHOD:&nbsp&nbspPUT</h5>' if show_in_doc && is_html_format
    puts_url url if show_in_doc && is_html_format
    puts_req JSON.pretty_generate(req) if req.to_s != '' && show_in_doc && is_html_format
    response_json = RestClient.put url, req.to_json, :content_type => :json, :accept => :json
    puts_resp JSON.pretty_generate(JSON.parse(response_json)) if response_json.to_s != '' && show_in_doc && is_html_format
    response_json
  end

  def post_json(url, req, show_in_doc = true)
    puts '<h5>METHOD:&nbsp&nbspPOST</h5>' if show_in_doc && is_html_format
    puts_url url if show_in_doc && is_html_format
    puts_req JSON.pretty_generate(req) if req.to_s != '' && show_in_doc && is_html_format
    response_json = RestClient.post url, req.to_json, :content_type => :json, :accept => :json
    puts_resp JSON.pretty_generate(JSON.parse(response_json)) if response_json.to_s != '' && show_in_doc && is_html_format
    response_json
  end
end