import { describe, it, expect, beforeEach } from "vitest"

// Mock storage for vehicles
const vehicles = new Map()
let nextVehicleId = 0

// Mock functions to simulate contract behavior
function registerVehicle(model: string, licensePlate: string, owner: string) {
  const vehicleId = nextVehicleId++
  vehicles.set(vehicleId, {
    owner,
    model,
    licensePlate,
    status: "active",
    registrationDate: Date.now(),
  })
  return vehicleId
}

function updateVehicleStatus(vehicleId: number, newStatus: string, sender: string) {
  const vehicle = vehicles.get(vehicleId)
  if (!vehicle) throw new Error("Vehicle not found")
  if (vehicle.owner !== sender) throw new Error("Unauthorized")
  vehicle.status = newStatus
  vehicles.set(vehicleId, vehicle)
  return true
}

function getVehicle(vehicleId: number) {
  return vehicles.get(vehicleId)
}

function isVehicleActive(vehicleId: number) {
  const vehicle = vehicles.get(vehicleId)
  return vehicle ? vehicle.status === "active" : false
}

describe("Vehicle Registration Contract", () => {
  beforeEach(() => {
    vehicles.clear()
    nextVehicleId = 0
  })
  
  it("should register a new vehicle", () => {
    const vehicleId = registerVehicle("Tesla Model 3", "ABC123", "owner1")
    expect(vehicleId).toBe(0)
    expect(vehicles.size).toBe(1)
    const vehicle = vehicles.get(0)
    expect(vehicle).toBeDefined()
    expect(vehicle.model).toBe("Tesla Model 3")
    expect(vehicle.licensePlate).toBe("ABC123")
    expect(vehicle.status).toBe("active")
  })
  
  it("should update vehicle status", () => {
    const vehicleId = registerVehicle("Tesla Model 3", "ABC123", "owner1")
    const result = updateVehicleStatus(vehicleId, "maintenance", "owner1")
    expect(result).toBe(true)
    const vehicle = vehicles.get(vehicleId)
    expect(vehicle.status).toBe("maintenance")
  })
  
  it("should not allow unauthorized status update", () => {
    const vehicleId = registerVehicle("Tesla Model 3", "ABC123", "owner1")
    expect(() => updateVehicleStatus(vehicleId, "inactive", "owner2")).toThrow("Unauthorized")
  })
  
  it("should retrieve vehicle information", () => {
    const vehicleId = registerVehicle("Tesla Model 3", "ABC123", "owner1")
    const vehicle = getVehicle(vehicleId)
    expect(vehicle).toBeDefined()
    expect(vehicle.model).toBe("Tesla Model 3")
    expect(vehicle.licensePlate).toBe("ABC123")
  })
  
  it("should check if a vehicle is active", () => {
    const vehicleId = registerVehicle("Tesla Model 3", "ABC123", "owner1")
    expect(isVehicleActive(vehicleId)).toBe(true)
    updateVehicleStatus(vehicleId, "inactive", "owner1")
    expect(isVehicleActive(vehicleId)).toBe(false)
  })
})

