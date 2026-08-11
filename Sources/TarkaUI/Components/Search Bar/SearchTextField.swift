//
//  SearchTextField.swift
//
//
//  Created by Gopinath on 10/08/23.
//

import SwiftUI

struct SearchTextField: View {
  
  @ObservedObject var searchBarVM: TUISearchBarViewModel
  @FocusState private var focusedItem: String?
  
  var body: some View {
    
    TextField(
      "",
      text: $searchBarVM.searchItem.text,
      prompt:
        Text(searchBarVM.searchItem.placeholder)
        .foregroundColor(.inputTextDim)
    )
    .focused($focusedItem, equals: searchBarVM.currentSearchBarID)
    .toolbar(content: toolbarDoneButtonView)
    .onChange(of: focusedItem) { _, newValue in
      searchBarVM.isEditing = newValue != nil
      guard let newValue, !newValue.isEmpty else { return }
      // If search on done is enabled,
      // when focus is removed ie. keyboard hides, perform search
      guard searchBarVM.needDelaySearch else { return }
      performSearch()
    }
    .onChange(of: searchBarVM.isEditing) { _, value in
      if value != (focusedItem != nil) {
        focusedItem = searchBarVM.currentSearchBarID
        searchBarVM.isFocused = value
      }
    }
    .onAppear {
      guard searchBarVM.searchButtonClicked != nil else { return }
      focusedItem = searchBarVM.currentSearchBarID
    }
    .onDisappear {
      searchBarVM.searchButtonClicked = nil
      searchBarVM.isEditing = false
      searchBarVM.isFocused = false
      focusedItem = .none
    }
    .accessibilityIdentifier(Accessibility.root)
    .submitLabel(searchBarVM.needDelaySearch ? .search : .return)
    .isEnabled(!searchBarVM.needDelaySearch) {
      $0.onChange(of: searchBarVM.searchItem.text) { updateSearchText($1) }
    }
  }
  
  private func performSearch() {
    searchBarVM.onEditing(searchBarVM.searchItem.text)
    searchBarVM.searchText = searchBarVM.searchItem.text
  }
  
  private func updateSearchText(_ value: String) {
    searchBarVM.onEditing(value)
    searchBarVM.searchText = value
  }
  
  @ToolbarContentBuilder
  private func toolbarDoneButtonView() -> some ToolbarContent {
    if focusedItem != nil, focusedItem == searchBarVM.currentSearchBarID {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("Done") { focusedItem = nil }
      }
    }
  }
}

extension SearchTextField {
  enum Accessibility: String, TUIAccessibility {
    case root = "SearchTextField"
  }
}


struct SearchBar_Previews: PreviewProvider {
  
  static var previews: some View {
    
    @StateObject var searchBarVM = TUISearchBarViewModel(
      searchItem: .init(placeholder: "Search", text: "")) { _ in }
    
    SearchTextField(searchBarVM: searchBarVM)
  }
}
