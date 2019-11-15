describe('users signin', () => {
  beforeEach(function() {
    cy.fixture('sign_in_user').as('validUser');
  });

  it('returns email and id of the current logged-in user', function() {
    cy.login(this.validUser).then(function() {
      cy.request({
        method: 'GET',
        url: '/me',
        headers: {
          authorization: `Bearer ${this.jwt}`
        }
      }).then(function(resp) {
        expect(resp.body).to.have.property('id');
        expect(resp.body).to.have.property('email');
        expect(resp.body.id).not.to.be.empty
        expect(resp.body.email).to.equal(this.validUser.email);
      })
      .its('body.id').as('userId')
    });
  });
});
