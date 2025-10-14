describe('Searchbar Visibility', () => {
  it('should not display searchbar by default', () => {
    cy.visit('/')

    // Assert searchbar is not present by default
    cy.get('.hdi-search-form').should('not.exist')
    cy.get('#search').should('not.exist')
  })
})
