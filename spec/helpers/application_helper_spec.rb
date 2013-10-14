require 'spec_helper'

describe ApplicationHelper do
  it 'has #default_page_title' do
    expect(helper.default_page_title).to(
      eq("#{controller_name.titleize} // #{I18n.t('sufia.product_name')}")
    )
  end

  it 'has #curation_concern_page_title' do
    expect(helper.curation_concern_page_title(GenericWork.new)).to(
      eq("New Generic Work // #{I18n.t('sufia.product_name')}")
    )
  end

  describe '#curation_concern_attribute_to_html' do
    it 'handles an array by rendering one <dd> per element' do
      collection = ["<h2>", "Johnny Tables"]
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      rendered.should have_tag('tr') do
        with_tag("th", text: 'Weird')
        with_tag('td ul.tabular') do
          with_tag('li.attribute.things', text: '<h2>')
          with_tag('li.attribute.things', text: 'Johnny Tables')
        end
      end
    end
    it 'handles a string by rendering one <dd>' do
      collection = "Tim"
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      rendered.should have_tag('tr') do
        with_tag("th", text: 'Weird')
        with_tag('td ul.tabular') do
          with_tag('li.attribute.things', text: 'Tim')
        end
      end
    end
    it 'returns a '' for a nil value' do
      collection = nil
      object = double('curation_concern', things: collection)

      expect(helper.curation_concern_attribute_to_html(object, :things, "Weird")).to(
        eq("")
      )
    end
    it 'returns a '' for an empty array' do
      collection = []
      object = double('curation_concern', things: collection)

      expect(helper.curation_concern_attribute_to_html(object, :things, "Weird")).to(
        eq("")
      )
    end
    it 'returns a string for an empty array if allow_empty is passed' do
      collection = []
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird", include_empty: true)
      rendered.should have_tag('tr') do
        with_tag("th", text: 'Weird')
        with_tag('td ul.tabular') do
          without_tag('li.attribute.things')
        end
      end
    end
  end

  it 'has #classify_for_display' do
    expect(helper.classify_for_display(GenericWork.new)).to eq('generic work')
  end

  describe '#link_to_edit_permissions' do
    let(:solr_document) {
      {
        Hydra.config[:permissions][:read][:group] => access_policy,
        Hydra.config[:permissions][:embargo_release_date] => embargo_release_date
      }
    }
    let(:user) { FactoryGirl.create(:user) }
    let(:curation_concern) {
      FactoryGirl.create_curation_concern(
        :generic_work, user, visibility: visibility
      )
    }
    let(:visibility) { nil }
    let(:access_policy) { nil }
    let(:embargo_release_date) { nil }
    describe 'with a "registered" access group' do
      let(:expected_label) { t('sufia.institution_name') }
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED } # Can we change this?
      let(:access_policy) { 'registered' }
      it 'renders an Institution only label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-info", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
    describe 'with a "public" access group' do
      let(:access_policy) { 'public' }
      describe 'without embargo release date' do
        let(:expected_label) { "Open Access" }
        let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}
        it 'renders an "Open Access" label' do
          rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
          expect(rendered).to(
            have_tag("a#permission_#{curation_concern.to_param}") {
              with_tag("span.label.label-success", with: {title: expected_label }, text: expected_label)
            }
          )
        end
      end

      describe 'with an embargo release date' do
        let(:expected_label) { "Open Access with Embargo" }
        let(:embargo_release_date) { Date.today.to_s }
        let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}
        it 'renders an "Open Access with Embargo" label' do
          rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
          expect(rendered).to(
            have_tag("a#permission_#{curation_concern.to_param}") {
              with_tag("span.label.label-warning", with: {title: expected_label }, text: expected_label)
            }
          )
        end
      end
    end

    describe 'with a mixed "public registered" access group' do
      # This test is purely speculative to the appropriate labeling behavior and
      # does not account for whether the document is truly accessable; I suppose
      # I'm persisting hash drive development via a Solr document
      let(:expected_label) { "Open Access" }
      let(:access_policy) { 'public registered' }
      it 'renders an "Open Access" label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-success", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
    describe 'without an access group' do
      let(:expected_label) { "Private" }
      let(:access_policy) { nil }
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      it 'renders an "Private" label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-important", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
  end
end
