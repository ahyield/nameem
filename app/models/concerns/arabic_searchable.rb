module ArabicSearchable
  extend ActiveSupport::Concern

  TASHKEEL = /[\u064B-\u065F\u0670]/
  ALEF_VARIANTS = /[\u0623\u0625\u0622]/
  TATWEEL = /\u0640/

  class_methods do
    def normalize_arabic(text)
      return "" if text.blank?

      text.gsub(TASHKEEL, "")
          .gsub(ALEF_VARIANTS, "\u0627")
          .gsub(TATWEEL, "")
    end
  end
end
