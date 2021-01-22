# frozen_string_literal: true

class SettingPresenter < AudioPresenter
  def selected_reciter
    load_recitations
      .find(recitation_id)
      .reciter
      .translated_name
  end

  def current_chapter
    Chapter.find(params[:chapter])
  end

  def recitations
    load_recitations
  end

  def languages
    strong_memoize :languages do
      list = Language.with_translations.eager_load(:translated_name)

      eager_load_translated_name(list).each_with_object({}) do |translation, hash|
        hash[translation.id] = translation
      end
    end
  end

  def translations
    list = ResourceContent
           .eager_load(:translated_name)
           .one_verse
           .translations
           .approved
           .order('priority ASC')

    translations = eager_load_translated_name(list)

    translations.group_by(&:language_id)
  end

  def selected_translation_count
    valid_translations.size
  end

  protected

  def load_recitations
    list = Recitation
           .eager_load(reciter: :translated_name)
           .approved

    eager_load_translated_name(list)
  end
end
