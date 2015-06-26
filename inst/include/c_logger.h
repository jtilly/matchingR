#ifndef LOGGER_H
#define LOGGER_H

#include <matchingR.h>

enum e_verbosity { ALL, WARNINGS, INFO, QUIET };

class c_log_message {
    public:
        c_log_message(const char *header, int importance, int level) {
            this->importance = importance;
            this->level = level;
            if (importance > level) {
                Rcout << header;
            }
        }
    
        c_log_message(bool result, int importance, int level) {
            Rcout << "[";
            if (result) {
                Rcout << "SUCCESS";
    
            } else {
                Rcout << "FAILURE";
            }
    
            Rcout << "] ";
        }
    
        ~c_log_message() {
            if (importance > level) {
                Rcout << "\n";
            }
        }
    
        template<typename T>
        c_log_message &operator<<(const T &t) {
            if (importance > level) {
                Rcout << t;
            }
            return *this;
        }
    private:
        int importance, level;
};

class c_logger {
    public:
        c_log_message error() {
            return c_log_message("[ERROR] ", 2, verbosity);
        }
        
        c_log_message info() {
            return c_log_message("[INFO] ", 3, verbosity);
        }
    
        c_log_message warning() {
            return c_log_message("[WARNING ]", 1, verbosity);
        }
    
        c_log_message test(bool result) {
            return c_log_message(result, 2, verbosity);
        }

        void configure(e_verbosity verbosity) {
            this->verbosity = verbosity;
        }
        
    private:
        // 0: Everything
        // 1: Error + Warnings
        // 2: Errors
        // 3: Quiet
        e_verbosity verbosity;
};

c_logger &log();

#endif
