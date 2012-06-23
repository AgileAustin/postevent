class BlogMailer < EventMailer
  def recipient
    Rails.configuration.blog_email
  end
end