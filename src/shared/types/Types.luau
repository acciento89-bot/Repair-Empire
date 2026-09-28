--!strict

export type CurrencyId = "cash" | "company_points"
export type CategoryId = "plumbing" | "heating" | "climate" | "energy"
export type DistrictId = "residential" | "downtown" | "industrial"
export type EnvironmentId = "development" | "production"

export type Service = {
	Name: string,
	Dependencies: { string }?,
	Init: ((self: Service) -> ())?,
	Start: ((self: Service) -> ())?,
}

export type RemoteDefinition = {
	Name: string,
	Kind: "Event" | "Function",
	RateLimitPerSecond: number,
}

return {}
