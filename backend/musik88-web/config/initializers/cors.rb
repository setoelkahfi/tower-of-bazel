Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '192.168.0.12:3002', '127.0.0.1:3002', 'localhost:3002', 'setoelkahfi.com', 'setoelkahfi.se',
            'beta.splitfire.ai', 'splitfire.ai', 'localhost:3003', 'msk88-web.vercel.app'
    resource '*', headers: :any, methods: %i[get post patch put delete], expose: ['Authorization']
  end
end
