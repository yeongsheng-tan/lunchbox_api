describe('users signin', () => {
  it('returns user json for valid credentials', () => {
    const validUser = {
      "email": "cypress_user@cypress.com",
      "password": "cyPR355.io"
    }

    const expectedSignInResp = {
      "data": {
        "user": {
          "email": "cypress_user@cypress.com",
          "id": 436870719699681281
        }
      }
    }

    cy.request('POST', '/users/sign_in', validUser)
      .its('body')
      .should('deep.eq', expectedSignInResp)
  })
})
