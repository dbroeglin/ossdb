//
// Common declarations
//

CREATE INDEX ON :ITEnv(code);

CREATE INDEX ON :IPv4Address(address);

// TODO: find a way to handle pre-existing constraints
// CREATE CONSTRAINT ON (ip:IPv4Address) ASSERT ip.address IS UNIQUE;

