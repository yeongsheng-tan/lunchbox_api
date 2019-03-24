describe('foods', () => {
  const signIn = () => {
    const validUser = {
      "email": "cypress_user@cypress.com",
      "password": "cyPR355.io"
    }

    // sign-in
    cy.request('POST', '/users/sign_in', validUser)
  }
  
  it('returns list of foods', () => {
    // sign-in first
    signIn()
    // get all foods
    cy.request('/foods')
      .its('body.data')
      .should('have.length', 5)
  })
  
  it('returns specific food item', () => {
    // sign-in first
    signIn()
    const caramelMocha = {
      "id": 434693139967377410,
      "name": "caramel-mocha",
      "status": "iced"
    }
    // get specific food item
    cy.request('/foods/434693139967377410')
      .its('body.data')
      .should('deep.eq', caramelMocha)
  })
})
