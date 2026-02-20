require "rails_helper"

RSpec.describe ArabicSearchable do
  let(:klass) do
    Class.new do
      include ArabicSearchable
    end
  end

  describe ".normalize_arabic" do
    it "strips tashkeel diacritics" do
      expect(klass.normalize_arabic("الكِتَابَة")).to eq("الكتابة")
    end

    it "normalizes alef with hamza above to plain alef" do
      expect(klass.normalize_arabic("أحمد")).to eq("احمد")
    end

    it "normalizes alef with hamza below to plain alef" do
      expect(klass.normalize_arabic("إبراهيم")).to eq("ابراهيم")
    end

    it "normalizes alef with madda to plain alef" do
      expect(klass.normalize_arabic("آمال")).to eq("امال")
    end

    it "strips tatweel/kashida" do
      expect(klass.normalize_arabic("كـتـاب")).to eq("كتاب")
    end

    it "handles combined normalizations" do
      expect(klass.normalize_arabic("الكِـتَـابَـة")).to eq("الكتابة")
    end

    it "returns empty string for nil" do
      expect(klass.normalize_arabic(nil)).to eq("")
    end

    it "returns empty string for blank" do
      expect(klass.normalize_arabic("")).to eq("")
      expect(klass.normalize_arabic("   ")).to eq("")
    end

    it "preserves non-Arabic text" do
      expect(klass.normalize_arabic("hello world")).to eq("hello world")
    end
  end
end
