describe('foods', () => {
  let jwtToken
  beforeEach(function() {
      const validUser = {
        "email": "cypress_user@cypress.com",
        "password": "cyPR355.io"
      }

    // sign-in
    cy.request('POST', '/sign_in', validUser).then((resp) => {
      expect(resp.body).to.have.property('jwt')
      jwtToken = resp.body.jwt
    })
  })
  
  it('returns list of foods', () => {
    // get all foods
    cy.request({method: 'GET', url: '/foods',
                headers: {authorization: `Bearer ${jwtToken}`}
              })
      .its('body.data')
      .should('not.be.empty')
  })
  
  it('returns specific food item', () => {
    const caramelMocha = {
      "id": 434693139967377410,
      "name": "caramel-mocha",
      "status": "iced"
    }
    // get specific food item
    cy.request({method: 'GET', url: '/foods/434693139967377410',
                headers: {authorization: `Bearer ${jwtToken}`}
              })
      .its('body.data')
      .should('deep.eq', caramelMocha)
  })
})
