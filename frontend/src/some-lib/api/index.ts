/**
 * @file index.ts
 * @description Central export point for all API-related functionality.
 * This file exports the API client, schema generator, and dynamically generated CRUD operations.
 */

export {
  generateSchemaTypes,
  generateTypeDeclarations,
  initializeSchemaTypes,
  type SchemaTypes,
} from "./schema-generator";

export { generateApiForSchema, generateCrudOperations } from "./crud";

// Dynamically generate and export API operations
import { generateApiForSchema } from "./crud";
import { generateSchemaTypes } from "./schema-generator";

export let api: ReturnType<typeof generateApiForSchema>;

export async function initializeApi() {
  const schemaTypes = await generateSchemaTypes();
  api = generateApiForSchema(schemaTypes);
}
