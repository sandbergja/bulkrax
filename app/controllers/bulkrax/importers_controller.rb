require_dependency "bulkrax/application_controller"
require_dependency "oai"

module Bulkrax
  class ImportersController < ApplicationController
    include Hyrax::ThemedLayoutController

    before_action :set_importer, only: [:show, :edit, :update, :destroy]
    with_themed_layout 'dashboard'

    # GET /importers
    def index
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb 'Importers', bulkrax.importers_path
      @importers = Importer.all
    end

    # GET /importers/1
    def show
    end

    # GET /importers/new
    def new
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb 'Importers', bulkrax.importers_path
      @importer = Importer.new
    end

    # GET /importers/1/edit
    def edit
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb 'Importers', bulkrax.importers_path
    end

    # POST /importers
    def create
      @importer = Importer.new(importer_params)

      if @importer.save
        redirect_to @importer, notice: 'Importer was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /importers/1
    def update
      if @importer.update(importer_params)
        redirect_to @importer, notice: 'Importer was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /importers/1
    def destroy
      @importer.destroy
      redirect_to importers_url, notice: 'Importer was successfully destroyed.'
    end

    def external_sets
      if list_external_sets
        render json: { base_url: params[:base_url], sets: @sets }
      else
        render json: { base_url: params[:base_url], error: "unable to pull data from #{params[:base_url]}" }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_importer
        @importer = Importer.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def importer_params
        params.require(:importer).permit(:name, :admin_set_id, :user_id, :frequency, :parser_klass, :limit, parser_fields: {}, field_mapping: {})
      end

      def list_external_sets
        url = params[:base_url] || (@harvester ? @harvester.base_url : nil)
        setup_client(url) if url.present?

        @sets = [['All', 'all']]

        begin
          @client.list_sets.each do |s|
            @sets << [s.name, s.spec]
          end
        rescue
          return false
        end

        @sets
      end

      def setup_client(url)
        return false if url.nil?

        headers = { from: 'server@atla.com' }

        @client ||= OAI::Client.new(url, headers: headers, parser: 'libxml', metadata_prefix: 'oai_dc')
      end
  end
end