describe('HDI Details Content Visibility', () => {
  beforeEach(() => {
    cy.visit('/?brand=hdi'); 
  });

  it('toggles visibility correctly', () => {
    const details = 'details.hdi-details';
    const summary = '.hdi-details__summary';
    const content = '.hdi-details__text';
  
    // Ensure it starts closed
    cy.get(details).should('not.have.attr', 'open');
  
    // Click to open
    cy.get(summary).click();
    cy.get(details).should('have.attr', 'open');
    cy.get(content).should('be.visible');
  
    // Click to close
    cy.get(summary).click();
    cy.get(details).should('not.have.attr', 'open');
  });
});
