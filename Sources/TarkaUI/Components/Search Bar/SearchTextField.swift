//
//  SearchTextField.swift
//
//
//  Created by Gopinath on 10/08/23.
//

import SwiftUI


struct SearchTextField: View {
  
  @ObservedObject var searchBarVM: TUISearchBarViewModel
  @FocusState private var isFocused: Bool
  
  var body: some View {
    
    TextField("", text: $searchBarVM.searchItem.text,
              prompt: Text(searchBarVM.searchItem.placeholder)
      .foregroundColor(.inputTextDim))
      .focused($isFocused)
      .onChange(of: isFocused) {
        searchBarVM.isEditing = $0
        guard !isFocused, searchBarVM.needDelaySearch else { return }
        // If delay search is enabled, on focus removed, perform search
        performSearch()
      }
      .onChange(of: searchBarVM.isEditing, perform: { value in
        if value != isFocused {
          isFocused = value
          searchBarVM.isFocused = value
        }
      })
      .onAppear {
        guard searchBarVM.searchButtonClicked != nil else { return }
        isFocused = true
      }
      .onDisappear {
        searchBarVM.searchButtonClicked = nil
      }
      .accessibilityIdentifier(Accessibility.root)
      .submitLabel(searchBarVM.needDelaySearch ? .search : .return)
      .isEnabled(!searchBarVM.needDelaySearch) {
        $0.onChange(of: searchBarVM.searchItem.text, perform: updateSearchText)
      }
  }
  
  private func performSearch() {
    guard searchBarVM.needDelaySearch else { return }
    searchBarVM.onEditing(searchBarVM.searchItem.text)
    searchBarVM.searchText = searchBarVM.searchItem.text
  }
  
  private func updateSearchText(_ value: String) {
    searchBarVM.onEditing(value)
    searchBarVM.searchText = value
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
