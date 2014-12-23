#encoding: UTF-8
shared_context "create better api doc", :api_doc => :api_doc do
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
    puts 'intranet.kalading.com' + s
    puts '<br/>HTTP Headers:</strong></h4><p><pre>Content-Type: application/json</pre></p><p><pre>Accept: application/json</pre></p>'
  end
  
  def is_html_format
    RSpec.configuration.formatters[0].is_a?(RSpec::Core::Formatters::HtmlFormatter)
  end

  # 封装rspec的get，为了产生API文档
  def get_with_better_doc(url, opts = {})
    puts '<h5>METHOD:&nbsp&nbspGET</h5>' if is_html_format
    puts_url url if is_html_format
    get_without_better_doc url, opts.merge({:format => 'json'})
    puts_resp JSON.pretty_generate(JSON.parse(response.body)) if is_html_format
  end

  alias_method_chain :get, :better_doc

  def put_with_better_doc(url, req)
    puts '<h5>METHOD:&nbsp&nbspPUT</h5>' if is_html_format
    puts_url url if is_html_format
    puts_req JSON.pretty_generate(req) if is_html_format
    put_without_better_doc url, req.merge({:format => 'json'})
    puts_resp JSON.pretty_generate(JSON.parse(response.body)) if is_html_format
  end
  alias_method_chain :put, :better_doc

  def post_with_better_doc(url, req)
    puts '<h5>METHOD:&nbsp&nbspPOST</h5>' if is_html_format
    puts_url url if is_html_format
    puts_req JSON.pretty_generate(req) if is_html_format
    post_without_better_doc url, req.merge({:format => 'json'})
    puts_resp JSON.pretty_generate(JSON.parse(response.body)) if is_html_format
  end
  alias_method_chain :post, :better_doc
end