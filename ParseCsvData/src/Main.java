import java.io.*;
import java.util.*;

public class Main {

    public static final int start = 1;
    public static final int end = 15;
    public static String dataDirectory = "/home/kylej/Documents/Kyle/Dev/HuskyADAPT/FallMonitoring/Fall_testing_processing/fixed_total_acc_CSV_COPY/";
    public static String outputDirectory = "/home/kylej/Documents/Kyle/Dev/HuskyADAPT/FallMonitoring/Fall_testing_processing/fixed_total_acc_OUT/";

    public static void main(String[] args) throws IOException {

        for (int curFile = start; curFile < end; curFile++) {
            File curF = new File(dataDirectory + "subject_" + curFile + "_final" + ".csv");
            //File exists?
            try {
                Scanner input = new Scanner(curF);
                //create output
                File outF = new File(outputDirectory + "out_" + curF.getName() + ".csv");
                if(outF.exists()) {
                    outF.delete();
                }
                outF.createNewFile();
                FileWriter out = new FileWriter(outF);
                //parse data
                parse(input, out);
                out.flush();
                out.close();
            } catch (FileNotFoundException e) {
                System.out.println("File " + curF.getName() + " does not exist.");
            }
        }
    }

    public static void parse(Scanner s, FileWriter out) throws IOException {
        int count = 0;
        int maxTotalAcc;
        String testName;
        while(s.hasNextLine()) {
            String line = s.nextLine();
            if(line.contains("TEST:")) {
                testName = line;
                String lineNext = s.nextLine();
                if(lineNext.contains("ACCEL VALS:")) {
                    count = countLine(s);
                }
                String dataLine = s.nextLine();
                String[] data = dataLine.split(",");
                String str_maxTotalAcc = data[data.length-1];
                maxTotalAcc = Integer.valueOf(str_maxTotalAcc);
                writeFile(out, testName, count, maxTotalAcc);
            }
        }
    }

    public static int countLine(Scanner s) {
        int lineCount = 0;
        while(!s.nextLine().contains("MAX ACCEL POS:")) {
            lineCount++;
        }
        return lineCount;
    }

    public static void writeFile(FileWriter out, String testName, int count, int maxTotalAcc) throws IOException {
        int fall = 0;
        if(testName.contains("Fall")) {
            fall = 1;
        }
        String concat = ",";
        out.write(testName + "\n");
        out.write(maxTotalAcc + "\n");
        out.write(count + "\n");
        out.write(fall + "\n");
    }
}
