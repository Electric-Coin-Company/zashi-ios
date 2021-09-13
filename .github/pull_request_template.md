This code review checklist is intended to serve as a starting point for the author and reviewer, although it may not be appropriate for all types of changes (e.g. fixing a spelling typo in documentation).  For more in-depth discussion of how we think about code review, please see [Code Review Guidelines](../blob/main/CODE_REVIEW_GUIDELINES.md).

# Author
<!-- NOTE: Do not modify these when initially opening the pull request.  This is a checklist template that you tick off AFTER the pull request is created. -->
- [ ] Self-review: Did you review your own code in GitHub's web interface? Code often looks different when reviewing the diff in a browser, making it easier to spot potential bugs.
- [ ] Automated tests: Did you add appropriate automated tests for any code changes?
- [ ] Code coverage: Did you check the code coverage report for the automated tests?  While we are not looking for perfect coverage, the tool can point out potential cases that have been missed.
- [ ] Documentation: Did you update Docs as appropiate? (E.g [README.md](../blob/main/README.md), etc.)
- [ ] Run the app: Did you run the app and try the changes? 
- [ ] Did you provide Screenshots of what the App looks like before and after your changes as part of the description of this PR? (only applicable to UI Changes)
- [ ] Rebase and squash: Did you pull in the latest changes from the main branch and squash your commits before assigning a reviewer? Having your code up to date and squashed will make it easier for others to review. Use best judgement when squashing commits, as some changes (such as refactoring) might be easier to review as a separate commit.


# Reviewer

- [ ] Checklist review: Did you go through the code with the [Code Review Guidelines](../blob/main/CODE_REVIEW_GUIDELINES.md) checklist?
- [ ] Ad hoc review: Did you perform an ad hoc review?  _In addition to a first pass using the code review guidelines, do a second pass using your best judgement and experience which may identify additional questions or comments. Research shows that code review is most effective when done in multiple passes, where reviewers look for different things through each pass._
- [ ] Automated tests: Did you review the automated tests?
- [ ] Manual tests: Did you review the manual tests?_You will find manual testing guidelines under our [manual testing section](../blob/mater/docs/testing/manual_testing)_
- [ ] How is Code Coverage affected by this PR? _We encourage you to compare coverage befor and after your changes and when possible, leave it in a better place. [Learn More...](../blob/master/docs/testing/local_coverage.md)_
- [ ] Documentation: Did you review Docs, [README.md](../blob/master/README.md), [LICENSE.md](../blob/master/LICENSE.md), and [Architecture.md](../blob/master/docs/Architecture.md) as appropriate?
- [ ] Run the app: Did you run the app and try the changes? While the CI server runs the app to look for build failures or crashes, humans running the app are more likely to notice unexpected log messages, UI inconsistencies, or bad output data.