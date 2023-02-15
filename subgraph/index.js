import { parse } from "graphql";
import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";
import { buildSubgraphSchema } from "@apollo/subgraph";

const server = new ApolloServer({
  schema: buildSubgraphSchema({
    typeDefs: parse(`
      type Query {
        me: User
      }

      type User {
        name: String
      }
    `),
    resolvers: {
      Query: {
        me: () => ({}),
      },
      User: {
        name: () => "hello via tailscale!",
      },
    },
  }),
});

const { url } = await startStandaloneServer(server, { listen: { port: 4111 } });
console.log(`subgraph ${url}`);
