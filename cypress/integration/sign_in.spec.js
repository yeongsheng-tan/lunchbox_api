describe('users signin', () => {
  let jwtToken
  const signupUser = {
    "user": {
      "email": "cypress_user@cypress.com",
      "password": "cyPR355.io",
      "password_confirmation": "cyPR355.io"
    }
  };

  const validUser = {
    "email": "cypress_user@cypress.com",
    "password": "cyPR355.io"
  };

  before(function() {
    // sign-up
    cy.request('POST', '/sign_up', signupUser).then((resp) => {
        expect(resp.body).to.have.property('jwt');
    });
  });

  it('returns user json for valid credentials', () => {
    cy.request('POST', '/sign_in', validUser).then((resp) => {
      expect(resp.body).to.have.property('jwt');
      expect(resp.body.jwt).to.be.a('string');
      expect(resp.body.jwt).to.not.be.empty;
      jwtToken = resp.body.jwt;
    });
  });

  it('returns email of the current logged-in user', () => {
    cy.request({method: 'GET', url: '/me',
                headers: {authorization: `Bearer ${jwtToken}`}
              }).then((resp) => {
                expect(resp.body).to.have.property('id');
                expect(resp.body).to.have.property('email');
                expect(resp.body.email).to.equal(validUser.email);

              });
  })
});
