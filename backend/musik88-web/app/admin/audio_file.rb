# frozen_string_literal: true

# TODO: Fix this later
# rubocop:disable Metrics/BlockLength
ActiveAdmin.register AudioFile do
  menu priority: 6, parent: 'SplitFire 🔥'
  permit_params :song_provider_id, :is_public, :locale

  index do
    selectable_column
    column 'Image', max_width: '200px', min_width: '100px' do |file|
      if file.song_provider.present? && file.song_provider.image_url.present?
        image_tag(file.song_provider.image_url, width: 200,
                                                height: 100)
      end
    end
    column :song_provider
    column 'Split results' do |file|
      if file.splitfire_results.count.positive?
        file.splitfire_results.each_with_index do |result, _index|
          a result.source_file.blob.filename, href: admin_splitfire_result_url(result)
          text_node ' | '.html_safe
          a 'edit', href: admin_splitfire_result_url(result)
          text_node '</br>'.html_safe
        end
        nil
      end
    end
    actions
  end

  filter :song_provider
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :song_provider
      row :source_file do |file|
        file.source_file.blob.filename if !file.source_file.nil? && !file.source_file.blob.nil?
      end
      row :created_at
      row :updated_at
    end
  end
end
