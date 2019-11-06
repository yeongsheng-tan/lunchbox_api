describe('foods', () => {
  let jwtToken
  const signupUser = {
      "user": {
          "email": "cypress_user1@cypress.com",
          "password": "cyPR355.io",
          "password_confirmation": "cyPR355.io"
      }
  };

  const validUser = {
      "email": "cypress_user1@cypress.com",
      "password": "cyPR355.io"
  };

  before(() => {
    // sign-up
    cy.request('POST', '/sign_up', signupUser).then((resp) => {
        expect(resp.body).to.have.property('jwt');
    });
    // sign-in
    cy.request('POST', '/sign_in', validUser).then((resp) => {
        expect(resp.body).to.have.property('jwt');
        jwtToken = resp.body.jwt;
    });
  });

  it('returns list of foods', () => {
      // create 2 food items
      cy.request({method: 'POST',
                  url: 'foods',
                  body: {
                    "food": {
                      "name": "coffee",
                      "status": "roasted"
                    }
                  },
                  headers: {authorization: `Bearer ${jwtToken}`}
                 });
      cy.request({method: 'POST',
                  url: 'foods',
                  body: {
                    "food": {
                      "name": "blue cheese",
                      "status": "well-aged"
                    }
                  },
                  headers: {authorization: `Bearer ${jwtToken}`}
                 });
    // get all foods
    cy.request({method: 'GET', url: '/foods',
                headers: {authorization: `Bearer ${jwtToken}`}
              })
        .its('body.data')
        .should('not.be.empty')
        .should('have.lengthOf', 2);
  });
})
