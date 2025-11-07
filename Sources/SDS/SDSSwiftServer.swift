//// The Swift Programming Language
//// https://docs.swift.org/swift-book
//

import Foundation
import ServiceLifecycle
import Logging
import System



//
//func setupServer(_ app: Application) async throws -> ServerService {
//    app.middleware.use(RequestLoggerInjectionMiddleware())
//    app.get("health") { _ in
//        "ok\n"
//    }
//    
//    app.get("docs") { req in
//        "accessed to docs"
//    }
//    
//    app.get("data") { req in
//        "accessed to students data"
//    }
//    
//    app.get("data/classrooms") { req in
//        "accessed to classrooms data"
//    }
//    
//    app.get("data/packs") { req in
//        "accessed to packs data"
//    }
//    
//    app.get("data/days") { req in
//        "accessed to days data"
//    }
//    
//    app.get("data/tranches") { req in
//        "accessed to tranches data"
//    }
//    
//    app.get("data/conferences") { req in
//        "accessed to conferences data"
//    }
//    
//    
//    app.get("perfs") { req -> String in
//    
//        let info = ProcessInfo.processInfo
//        
//        #if arch(x86_64)
//        let arch = "x86_64"
//#elseif arch(arm64)
//        let arch = "ARM64"
//        #else
//        let arch = "Another"
//        #endif
//        
//        var cpuString = ""
//        
//        if let cpu = getCPU("machdep.cpu.brand_string") {
//            cpuString = cpu
//        } else {
//            cpuString = "Unknwon"
//        }
//        
//        
//        return "\(info.operatingSystemVersionString), \(info.hostName), \(info.physicalMemory), \(info.processorCount), \(info.activeProcessorCount), \(info.systemUptime), \(arch), \(cpuString)"
//        
//    }
//    
//    return ServerService(app: app)
//}
//
//
//
//func getCPU(_ key: String) -> String? {
//    var size = 0
//    sysctlbyname(key, nil, &size, nil, 0)
//    var value = [CChar](repeating: 0, count: size)
//    sysctlbyname(key, &value, &size, nil, 0)
//    return String(cString: value)
//}
//





//struct MachinePerformance: Content {
//    
//    let name: String
//    let cpusCount: String
//    
//    
//    init(name: String, cpusCount: String) {
//        self.name = name
//        self.cpusCount = cpusCount
//    }
//    
//}

