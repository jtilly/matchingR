#ifndef LOGGER_H
#define LOGGER_H

#include <matchingR.h>

enum e_verbosity { ALL, INFO, WARNINGS, QUIET };

class c_log_message {
    public:
        c_log_message(const char *header, int importance, int level) {
            this->importance = importance;
            this->level = level;
            if (importance > level) {
                Rcpp::Rcout << header;
            }
        }
    
        c_log_message(bool result, int importance, int level) {
            Rcpp::Rcout << "[";
            if (result) {
                Rcpp::Rcout << "SUCCESS";
    
            } else {
                Rcpp::Rcout << "FAILURE";
            }
    
                Rcpp::Rcout << "] ";
        }
    
        ~c_log_message() {
            if (importance > level) {
                Rcpp::Rcout << "\n";
            }
        }
    
        template<typename T>
        c_log_message &operator<<(const T &t) {
            if (importance > level) {
                Rcpp::Rcout << t;
            }
            return *this;
        }
        
        c_log_message &operator<<(std::vector<size_t> &t) {
            if (importance > level) {
                for (size_t i = 0; i < t.size(); ++i) {
                    Rcpp::Rcout << t[i] << ", ";
                }
            }
            return *this;
        }
    private:
        int importance, level;
};

class c_logger {
    public:
        c_log_message error() {
            return c_log_message("[ERROR] ", 3, verbosity);
        }
        
        c_log_message info() {
            return c_log_message("[INFO] ", 1, verbosity);
        }
    
        c_log_message warning() {
            return c_log_message("[WARNING] ", 2, verbosity);
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
