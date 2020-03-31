# frozen_string_literal: true

class NotSpamValidator < ActiveModel::EachValidator
  SPAM_PHRASES = %w[
    affordable
    aged
    alcohol
    backlink
    boyfriend
    brand
    business
    cafergot
    casino
    cheap
    cialis
    coupon
    credit
    gift
    girlfriend
    investment
    laminine
    leads
    medication
    merchant
    payment
    porn
    pills
    rehab
    relationship
    russia
    sex
    slot
    testimonials
    viagra
  ].freeze

  BAD_TLDS = %w[
    cc
    ru
    tk
    top
  ].freeze

  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    record.errors.add(attribute, options[:message] || :is_spam) if is_spam?(value)
  end

  private

  def contains_bad_links?(value)
    BAD_TLDS.any? { |bad_tld| value =~ /.+\.#{bad_tld}/ }
  end

  # I can't imagine a case where I would ever get a legitimate message in Russian.
  def contains_cyrillic_characters?(value)
    value =~ /\p{Cyrillic}/
  end

  def contains_spam_phrases?(value)
    downcased_value = value.downcase

    SPAM_PHRASES.any? { |spam| downcased_value.include?(spam) }
  end

  def is_spam?(value)
    contains_bad_links?(value) ||
      contains_cyrillic_characters?(value) ||
      contains_spam_phrases?(value)
  end
end
