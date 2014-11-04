module Guides
  class CreateGuide < Mutations::Command
    attr_writer :guide

    include Guides::GuidesConcern

    required do
      model :user
      string :crop_id
      string :name
    end

    optional do
      string :overview
      string :featured_image
      string :location
    end

    def guide
      @guide ||= Guide.new
    end

    def validate
      validate_crop
      validate_image_url
    end

    def execute
      set_params
      guide
    end

    def set_params
      # TODO: Figure out why Guide.create(@inputs) is broke
      guide.crop           = @crop
      guide.name           = name
      guide.user           = user
      guide.overview       = overview if overview
      guide.location       = location if location
      guide.save
      # TODO : Verify that we actually need to do this:
      set_featured_image_async
    end

    def validate_crop
      @crop = Crop.find(crop_id)
    rescue Mongoid::Errors::DocumentNotFound
      msg = "Could not find a crop with id #{crop_id}."
      add_error :crop_id, :crop_not_found, msg
    end
  end
end
