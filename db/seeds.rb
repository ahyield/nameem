# frozen_string_literal: true

# Create a main user.
User.create!(name: "نميم", email: "account@nameem.com", slug: "nameem",
             bio: "اسم عربي، صوت حركة خفية، صوت الخطوة في الظلام، وصوت الكتابة. وهو الكلام الذي يثير الفِتَنْ، أحيانًا.",
             confirmed: true, editor: true, admin: true)
