#ifndef LOGGER_H
#define LOGGER_H

#include <matchingR.h>

enum e_verbosity { ALL, INFO, WARNINGS, QUIET };

class log_message {
    public:
        log_message(const char *header, int importance, int level) {
            this->importance = importance;
            this->level = level;
            if (importance > level) {
                Rcpp::Rcout << header;
            }
        }
    
        log_message(bool result, int importance, int level) {
            Rcpp::Rcout << "[";
            if (result) {
                Rcpp::Rcout << "SUCCESS";
    
            } else {
                Rcpp::Rcout << "FAILURE";
            }
    
                Rcpp::Rcout << "] ";
        }
    
        ~log_message() {
            if (importance > level) {
                Rcpp::Rcout << "\n";
            }
        }
    
        template<typename T>
        log_message &operator<<(const T &t) {
            if (importance > level) {
                Rcpp::Rcout << t;
            }
            return *this;
        }
        
        log_message &operator<<(std::vector<uword> &t) {
            if (importance > level) {
                for (uword i = 0; i < t.size(); ++i) {
                    Rcpp::Rcout << t[i] << ", ";
                }
            }
            return *this;
        }
        
        log_message &operator<<(std::deque<uword> &t) {
            if (importance > level) {
                for (uword i = 0; i < t.size(); ++i) {
                    Rcpp::Rcout << t[i] << ", ";
                }
            }
            return *this;
        }
    private:
        int importance, level;
};

class logger {
    public:
        log_message error() {
            return log_message("[ERROR] ", 3, verbosity);
        }
        
        log_message info() {
            return log_message("[INFO] ", 1, verbosity);
        }
    
        log_message warning() {
            return log_message("[WARNING] ", 2, verbosity);
        }
    
        log_message test(bool result) {
            return log_message(result, 2, verbosity);
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

logger &log();

#endif
