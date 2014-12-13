Paperclip::Attachment.default_options[:storage] = :qiniu
Paperclip::Attachment.default_options[:qiniu_credentials] = {
  :access_key => 'ZGjmw9DfIAf9xw7c_zQZaoGRLvGPkifPClEvoq8S',
  :secret_key => 'YAiXyuit-d5_RpHmrQ2396Gd-rjwduI76tz--WqP'
}
Paperclip::Attachment.default_options[:bucket] = 'kalading'
Paperclip::Attachment.default_options[:use_timestamp] = false
Paperclip::Attachment.default_options[:qiniu_host] =
  'http://kalading.qiniudn.com'
