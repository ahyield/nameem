require "rails_helper"

RSpec.describe "Backoffice" do
  let(:admin) { create(:user, :admin) }

  before { system_sign_in(admin) }

  it "toggles a role with a switch and keeps it after a reload" do
    member = create(:user)
    visit backoffice_user_path(member)

    expect(page).to have_css("#role-featured[aria-checked='false']")
    find("#role-featured").click

    expect(page).to have_css("#role-featured[aria-checked='true']")
    visit backoffice_user_path(member)
    expect(page).to have_css("#role-featured[aria-checked='true']")
    expect(member.reload).to be_featured
  end

  it "renames and merges tags" do
    poetry = Tag.create!(name: "شعر")
    verse = Tag.create!(name: "قصائد")
    create(:article, :published).tags << verse

    visit backoffice_tag_path(verse)
    fill_in "tag[name]", with: "قصيدة"
    click_on "حفظ"
    expect(page).to have_content("تم تحديث الموضوع بنجاح")

    select "#{poetry.name} (0)", from: "target_id"
    accept_confirm { click_on "دمج" }
    expect(page).to have_content("تم دمج الموضوع بنجاح")
    expect(Tag.exists?(verse.id)).to be(false)
    expect(poetry.reload.articles_count).to eq(1)
  end
end
