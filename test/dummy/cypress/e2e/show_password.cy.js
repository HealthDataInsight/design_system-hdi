describe('Show Password', () => {

  it('should toggle password visibility and button text', () => {
    cy.visit('/assistants/new')

    cy.contains('password')
    
    cy.get('[data-ds--show-password-target="password"]')
      .should('have.attr', 'type', 'password')
    
    cy.get('button[aria-label="Show password"]').click()

    cy.get('button[aria-label="Show password"]').click()
      .click()

    cy.get('[data-ds--show-password-target="password"]')
      .should('have.attr', 'type', 'text')
    
     // Hide Password functionality but here the button text isn't present rather icon
     // so using same aria-label property to see toggle feature 
    cy.get('button[aria-label="Show password"]').click()

    cy.get('button[aria-label="Show password"]').click()
      .click()

    cy.get('[data-ds--show-password-target="password"]')
      .should('have.attr', 'type', 'password')
    
    cy.get('button[aria-label="Show password"]').should('exist')
  })
})
