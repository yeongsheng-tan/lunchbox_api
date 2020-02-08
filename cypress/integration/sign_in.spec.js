describe('users signin', () => {
  before(function() {
    cy.exec("export DB_PORT=26257 && mix ecto.drop && mix ecto.setup && mix ecto.migrate");
    cy.fixture('sign_up_user').as('signUpUser');
    cy.fixture('sign_in_user').as('validUser');
  });

  it('returns email and id of the current logged-in user', function() {
    cy.signup(this.signUpUser).then(function() {
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
          expect(resp.body.id).not.to.be.null;
          expect(resp.body.email).to.equal(this.validUser.email);
        })
        .its('body.id').as('userId');
      });
    });
  });
});
