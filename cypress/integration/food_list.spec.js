describe('foods', () => {
  before(function() {
    cy.exec("export DB_PORT=26257 && mix ecto.drop && mix ecto.setup && mix ecto.migrate");
    cy.fixture('sign_up_user').as('signUpUser');
    cy.fixture('sign_in_user').as('validUser');
  });

  it('returns list of foods', function() {
    cy.signup(this.signUpUser).then(function() {
      cy.login(this.validUser).then(function() {
        // create 2 food items
        cy.request({
          method: 'POST',
          url: 'foods',
          body: {
            "food": {
              "name": "coffee",
              "status": "roasted"
            }
          },
          headers: {
            authorization: `Bearer ${this.jwt}`
          }
        });

        cy.request({
          method: 'POST',
          url: 'foods',
          body: {
            "food": {
              "name": "blue cheese",
              "status": "well-aged"
            }
          },
          headers: {
            authorization: `Bearer ${this.jwt}`
          }
        });

        // get all foods
        cy.request({
          method: 'GET',
          url: '/foods',
          headers: {
            authorization: `Bearer ${this.jwt}`
          }
        })
        .its('body.data')
        .should('not.be.empty')
        .should('have.lengthOf', 2);
      });

    });
  });
});
