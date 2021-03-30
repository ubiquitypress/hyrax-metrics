# frozen_string_literal: true
require "hyrax/hirmeos/client"

class Hyrax::Hirmeos::WorkFactory
  def self.for(resource:)
    work = Hyrax::Hirmeos::Client::Work.new
    work.title = resource.title
    work.uri = [{ uri: resource_url(resource), canonical: true },
                { uri: resource.id }
               ]
    work.type = "other" # Need to map Hyrax work type to configured work types in HIRMEOS
    file_urls = self.add_file_urls(resource)
    work.uri << file_urls unless file_urls.blank?
    work.uri.flatten!
    work
  end

  def self.resource_url(work)
    Rails.application.routes.url_helpers.polymorphic_url(work)
  end

  def self.add_file_urls(work)
    files = work.file_sets
    return unless files.present?
    links = files.map {|file| Hyrax::Engine.routes.url_helpers.download_url(id: file, locale: 'en')}
    links.each_slice(1).map { |link| Hash[[:uri].zip(link)] }
  end
end
