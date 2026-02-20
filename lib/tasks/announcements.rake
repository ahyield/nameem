namespace :announcements do
  desc "Send new features announcement (Feb 2026) to all confirmed users via Mailgun batch API"
  task february_2026: :environment do
    api_key = Rails.application.credentials.dig(:mailgun, :api_key)
    domain = "mail.nameem.com"

    mg_client = Mailgun::Client.new(api_key)
    batch = Mailgun::BatchMessage.new(mg_client, domain)

    batch.from("نميم <noreply@nameem.com>")
    batch.subject("جديد نميم — ميزات جديدة في فبراير")
    batch.body_html(february_2026_html)

    users = User.confirmed.where.not(email: nil)
    total = users.count

    abort "No confirmed users found." if total.zero?

    puts "Sending announcement to #{total} users..."

    users.find_each do |user|
      batch.add_recipient(:to, user.email, { "name" => user.name.to_s })
    end

    batch.finalize
    puts "Done! #{total} emails queued with Mailgun."
  end
end

def february_2026_html
  <<~HTML
    <!DOCTYPE html>
    <html lang="ar" dir="rtl" xmlns:v="urn:schemas-microsoft-com:vml">
    <head>
      <meta charset="utf-8">
      <meta name="x-apple-disable-message-reformatting">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="format-detection" content="telephone=no, date=no, address=no, email=no, url=no">
      <meta name="color-scheme" content="light dark">
      <meta name="supported-color-schemes" content="light dark">
      <!--[if mso]>
      <noscript>
        <xml>
          <o:OfficeDocumentSettings xmlns:o="urn:schemas-microsoft-com:office:office">
            <o:PixelsPerInch>96</o:PixelsPerInch>
          </o:OfficeDocumentSettings>
        </xml>
      </noscript>
      <style>
        td,th,div,p,a,h1,h2,h3,h4,h5,h6 {font-family: "Segoe UI", sans-serif; mso-line-height-rule: exactly;}
      </style>
      <![endif]-->
      <title>ميزات جديدة على نميم</title>
      <style>
        body { margin: 0; padding: 0; width: 100%; word-break: break-word; -webkit-font-smoothing: antialiased; background-color: #fff; font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif; }
        img { max-width: 100%; vertical-align: middle; line-height: 1; border: 0; }
        .container { max-width: 552px; margin: 0 auto; }
        .card { padding: 48px; background: #fff; border-radius: 4px; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1); }
        .feature-icon { display: inline-block; width: 48px; height: 48px; border-radius: 50%; text-align: center; line-height: 48px; font-size: 22px; margin-bottom: 8px; }
        .btn { display: inline-block; padding: 12px 32px; background-color: #3b82f6; color: #fff; text-decoration: none; border-radius: 4px; font-weight: 600; font-size: 16px; }
        @media (max-width: 600px) {
          .card { padding: 24px !important; }
        }
      </style>
    </head>
    <body dir="rtl">
      <div style="padding-top: 80px; padding-bottom: 48px;">
        <table align="center" cellpadding="0" cellspacing="0" role="none">
          <tr>
            <td class="container" style="max-width: 552px; width: 100%;">

              <div style="margin: 48px 0; text-align: center;">
                <a href="https://nameem.com">
                  <img src="https://nameem.com/assets/brand/logo-ba62e14561c8a79c1b1eaa3b75f2e6a08c7dcbe60a83c3d77ea0d4a1131a7764.png" width="70" alt="نميم">
                </a>
              </div>

              <table style="width: 100%;" cellpadding="0" cellspacing="0" role="none">
                <tr>
                  <td class="card" style="padding: 48px; text-align: center; font-size: 16px; color: #334155; background: #fff; border-radius: 4px; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.1);">

                    <h1 style="margin: 0 0 24px; font-size: 24px; color: #000; font-weight: 600;">
                      ميزات جديدة على نميم
                    </h1>

                    <p style="margin: 0 0 8px; line-height: 1.6;">
                      مرحبًا %recipient.name%،
                    </p>

                    <p style="margin: 0 0 32px; line-height: 1.6;">
                      أضفنا مجموعة من الميزات الجديدة لتجعل تجربتك على نميم أفضل:
                    </p>

                    <!-- Row 1: Following + Topics -->
                    <table style="width: 100%; margin-bottom: 16px;" cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding: 16px; text-align: center; vertical-align: top; width: 50%;">
                          <div class="feature-icon" style="background-color: #eff6ff;">
                            &#128101;
                          </div>
                          <h3 style="margin: 8px 0 4px; font-size: 16px; color: #000;">المتابعة</h3>
                          <p style="margin: 0; font-size: 14px; color: #64748b; line-height: 1.5;">
                            تابع كتّابك المفضلين وشاهد مقالاتهم الجديدة في صفحة المتابَعين
                          </p>
                        </td>
                        <td style="padding: 16px; text-align: center; vertical-align: top; width: 50%;">
                          <div class="feature-icon" style="background-color: #f0fdf4;">
                            &#128278;
                          </div>
                          <h3 style="margin: 8px 0 4px; font-size: 16px; color: #000;">المواضيع</h3>
                          <p style="margin: 0; font-size: 14px; color: #64748b; line-height: 1.5;">
                            تصفّح المقالات حسب الموضوع واكتشف ما يهمّك بسهولة
                          </p>
                        </td>
                      </tr>
                    </table>

                    <!-- Row 2: Social Links + New Home -->
                    <table style="width: 100%; margin-bottom: 32px;" cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding: 16px; text-align: center; vertical-align: top; width: 50%;">
                          <div class="feature-icon" style="background-color: #faf5ff;">
                            &#127760;
                          </div>
                          <h3 style="margin: 8px 0 4px; font-size: 16px; color: #000;">حسابات التواصل</h3>
                          <p style="margin: 0; font-size: 14px; color: #64748b; line-height: 1.5;">
                            أضف روابط حساباتك على X وانستقرام وفيسبوك وموقعك الشخصي إلى ملفك
                          </p>
                        </td>
                        <td style="padding: 16px; text-align: center; vertical-align: top; width: 50%;">
                          <div class="feature-icon" style="background-color: #fef2f2;">
                            &#10024;
                          </div>
                          <h3 style="margin: 8px 0 4px; font-size: 16px; color: #000;">الصفحة الرئيسية</h3>
                          <p style="margin: 0; font-size: 14px; color: #64748b; line-height: 1.5;">
                            صفحة رئيسية جديدة بتبويبات الأحدث والأكثر شعبية ومختارات نميم
                          </p>
                        </td>
                      </tr>
                    </table>

                    <a href="https://nameem.com" class="btn" style="display: inline-block; padding: 12px 32px; background-color: #3b82f6; color: #fff; text-decoration: none; border-radius: 4px; font-weight: 600; font-size: 16px;">
                      استكشف نميم
                    </a>

                  </td>
                </tr>

                <tr>
                  <td style="line-height: 48px;">&zwj;</td>
                </tr>

                <tr>
                  <td style="text-align: center; color: #475569; font-size: 12px; padding: 0 24px;">
                    <p style="margin: 0 0 16px; text-transform: uppercase;">
                      نميم
                    </p>
                    <p style="margin: 0;">
                      <a href="mailto:support@nameem.com" style="color: #4338ca; text-decoration: none;">الدعم</a>
                      &bull;
                      <a href="https://x.com/nameemofficial" style="color: #4338ca; text-decoration: none;">X</a>
                    </p>
                  </td>
                </tr>
              </table>

            </td>
          </tr>
        </table>
      </div>
    </body>
    </html>
  HTML
end
