describe('users signin', () => {
  const validUser = {
    "email": "cypress_user@cypress.com",
    "password": "cyPR355.io"
  }

  it('returns user json for valid credentials', () => {
    cy.request('POST', '/sign_in', validUser).then((resp) => {
      expect(resp.body).to.have.property('jwt')
      expect(resp.body.jwt).to.be.a('string')
      expect(resp.body.jwt).to.not.be.empty
    })
  })
})
