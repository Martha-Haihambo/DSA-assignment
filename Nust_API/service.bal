import ballerina/http;
import ballerina/time;

public type Course record {
    readonly string CourseCode;
    string courseName;
    int NQFLevel;
};

public type Programme record {
    readonly string ProgrammeCode;
    string ProgrammeName; 
    string ProgrammeTitle;
    int NQFLevel;
    string Faculty;
    string department;
    time:Civil RegistrationDate;
    Course[] courses;
};

public final table<Programme> key(ProgrammeCode) programmeTable = table [
    {
        ProgrammeCode: "BCS01",
        ProgrammeName: "BSc Computer Science",
        ProgrammeTitle: "Bachelor of Science in Computer Science",
        NQFLevel: 8,
        Faculty: "Computing and Informatics",
        department: "Computer Science",
        RegistrationDate: { year: 2017, month: 6, day: 10, hour: 0, minute: 0, second: 0 },
        courses: [
            { CourseCode: "CS101", courseName: "Introduction to Programming", NQFLevel: 5 },
            { CourseCode: "CS201", courseName: "Data Structures", NQFLevel: 6 }
        ]
    }
];

service on new http:Listener(4000) {


        resource function post Programmes(Programme newProgramme) returns string {
    programmeTable.add(newProgramme);
    return "The Programme " + newProgramme.ProgrammeName + " is saved" ;
}
      resource function get all() returns string[] {
        string[] programmeNames = [];
        foreach Programme prog in programmeTable {
            programmeNames.push(prog.ProgrammeName);
        }
        return programmeNames;
    }

   

  
    resource function put Programme/[string programmeCode](@http:Payload Programme updatedProgramme) returns json {
        Programme? existingProgramme = programmeTable.get(programmeCode);
        if (existingProgramme is Programme) {
            var result = programmeTable.remove(programmeCode);
            programmeTable.add(updatedProgramme);
            return { "status": "Programme " + updatedProgramme.ProgrammeName + " updated successfully" };
        } else {
            return { "error": "Programme with code " + programmeCode + " not found" };
        }
    }

       resource function get Programme/[string programmeCode]() returns Programme|json {
     if programmeTable.hasKey(programmeCode) {
        Programme? programme = programmeTable.get(programmeCode);
        return programme;
    } else {
        return { "error": "Programme with code " + programmeCode + " not found" };
    }
}


resource function delete Programme/[string programmeCode]() returns Programme|json {

    if programmeTable.hasKey(programmeCode) {
       
        Programme? removedProgramme = programmeTable.remove(programmeCode);
        return { "status": "Programme with code " + programmeCode + " deleted successfully"}; 
        }else {
        
        return {"status": "Programme with code " + programmeCode + " not found"};
        }
           
    }
    
  
    resource function get dueForReview() returns Programme[] {
        Programme[] dueProgrammes = [];
        time:Utc currentTime = time:utcNow();
        time:Civil currentDate = time:utcToCivil(currentTime);
        foreach Programme prog in programmeTable {
            int yearsSinceRegistration = currentDate.year - prog.RegistrationDate.year;
            if (yearsSinceRegistration >= 5) {
                dueProgrammes.push(prog);
            }
        }
        return dueProgrammes;
    }


    resource function get programmesByFaculty/[string faculty]() returns Programme[] {
        Programme[] facultyProgrammes = [];
        foreach Programme prog in programmeTable {
            if (prog.Faculty.toLowerAscii() == faculty.toLowerAscii()) {
                facultyProgrammes.push(prog);
            }
        }
        return facultyProgrammes;
    }

 
}
