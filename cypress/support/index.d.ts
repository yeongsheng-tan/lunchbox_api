/// <reference types="cypress" />

declare namespace Cypress {
  type User = {
    email: string;
    password: string;
  };

  interface Chainable<Subject> {
    /**
     * Login to Lunchbox API
     * @memberof Cypress.Chainable
     * @example
     * cy.login({email: 'user@cypress.com', password: 'myPassword'})
     */
    login: (user: User) => Chainable<boolean>;
    /**
     * Creates one Todo using UI
     * @memberof Cypress.Chainable
     * @example
     * cy.signup({email: 'user@cypress.com', password: 'myPassword'})
     */
    signup: (user: User) => Chainable<boolean>;
  }
}
